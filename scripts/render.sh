#!/usr/bin/env bash
#
# Tange, O. (2020, May 22). GNU Parallel 20200522 ('Kraftwerk').
#  Zenodo. https://doi.org/10.5281/zenodo.3841377


set -e

TYPE='svg'
BASE_DIRECTORY='.'

function usage {
    echo "$(basename $0) [-b base-directory][-o output-directory] [-t type] [-w] [-h]"
    echo ""
    echo "      -b base-directory: Directory to start searching for drawio files, default to '${BASE_DIRECTORY}'"
    echo "      -o output-directory: Render all files into the same output directory. By default, renders files next to the original drawio files."
    echo "      -t type: The output type, defaults to '${TYPE}'."
    echo "      -s: Skip. Don't render diagrams already present on disk."
    echo "      -w: Watch. This watches all drawio files and regenerates the ones that are modified."
    echo "      -h: This menu"
}

while getopts "b:o:t:swh" arg; do
    case ${arg} in
    b)
        BASE_DIRECTORY=${OPTARG}
        ;;
    o)
        OUTPUT_DIR=${OPTARG}
        ;;
    t)
        TYPE=${arg}
        ;;
    s)
        SKIP='true'
        ;;
    w)
        WATCH='true'
        ;;
    h)
        usage
        exit 0
        ;;
    *)
        usage
        exit 1
        ;;
    esac
done

if [[ -n ${OUTPUT_DIR} && ! -d ${OUTPUT_DIR} ]] ; then
    echo "Output Directory not a directory: ${OUTPUT_DIR}"
    exit 1
fi

if [[ -n ${OUTPUT_DIR} ]] ; then
    # De-reference output directory
    OUTPUT_DIR=$(cd ${OUTPUT_DIR} && pwd)
fi

if [[ ! -d ${BASE_DIRECTORY} ]] ; then
    echo "Base Directory not a directory: ${BASE_DIRECTORY}"
else
    BASE_DIRECTORY=$(cd ${BASE_DIRECTORY} &&pwd)
fi

# Prepare output cleaning
touch "${DRAWIO_DESKTOP_SOURCE_FOLDER:?}/unwanted-lines.txt"
if [[ "${ELECTRON_DISABLE_SECURITY_WARNINGS:?}" == "true" ]]; then
  cat "${DRAWIO_DESKTOP_SOURCE_FOLDER:?}/unwanted-security-warnings.txt" >>"${DRAWIO_DESKTOP_SOURCE_FOLDER:?}/unwanted-lines.txt"
fi

if [[ "${DRAWIO_DISABLE_UPDATE:?}" == "true" ]]; then
  # Remove 'deb support' logs
  # since 'autoUpdater.logger.transports.file.level' is set as 'info' on drawio-desktop
  cat "${DRAWIO_DESKTOP_SOURCE_FOLDER:?}/unwanted-update-logs.txt" >>"${DRAWIO_DESKTOP_SOURCE_FOLDER:?}/unwanted-lines.txt"
fi

function render() {
    FILE=${1}
    TYPE=${2}
    SKIP=${3}
    OUTPUT_DIR=${4}

    OUTPUT_FILENAME="${FILE%.*}.${TYPE}"
    if [[ -n ${OUTPUT_DIR} ]] ; then
        OUTPUT_FILENAME="${OUTPUT_DIR}/$(basename "${OUTPUT_FILENAME}")"
    fi

    if [[ "${SKIP}" == 'true' ]] ; then
        if [[ -f ${OUTPUT_FILENAME} ]] ; then
            echo "${OUTPUT_FILENAME} exists. Skipping ${FILE}"
            exit 0
        fi
    fi

    echo -n "Rendering "
    timeout "${DRAWIO_DESKTOP_COMMAND_TIMEOUT}" "${DRAWIO_DESKTOP_SOURCE_FOLDER:?}/runner_wrapper.sh" --export --format ${TYPE} --output ${OUTPUT_FILENAME} ${FILE} || true
}

# clean lock files
find / -name "*-lock" -type f -exec rm {} \; 2> /dev/null || true

# Start framebuffer and make sure its cleaned up after each run
export DISPLAY="${XVFB_DISPLAY}"
Xvfb "${XVFB_DISPLAY}" ${XVFB_OPTIONS} &
XVFB_PID=$!
trap "kill -9 ${XVFB_PID}" EXIT

export -f render

NUM_CPUS=$(nproc --all)

find ${BASE_DIRECTORY} -type f -name "*.drawio" | parallel -j${NUM_CPUS} render {} "${TYPE}" "${SKIP:-false}" "${OUTPUT_DIR}"

if [[ -z "${WATCH}" ]] ; then
    exit 0
fi

echo "Watching files in ${BASE_DIRECTORY}"

# Workaround because inotifywait doesn't behave on docker for mac
export ENTR_INOTIFY_WORKAROUND="yes"
find ${BASE_DIRECTORY} -type f -name "*.drawio" | entr -r -p render /_ "${TYPE}" "false" "${OUTPUT_DIR}"
