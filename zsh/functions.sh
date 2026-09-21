pod_get() {
    local NAMESPACE="${1:-}"
    local POD_QUERY="${2:-}"
    local REMOTE_PATH="${3:-}"
    local LOCAL_PATH="${4:-.}"

    if [[ -z "$NAMESPACE" || -z "$POD_QUERY" || -z "$REMOTE_PATH" ]]; then
        echo "Usage: pod_get <namespace> <pod-name-or-prefix> <remote-path> [local-path]" >&2
        return 1
    fi

    local POD_NAME
    POD_NAME="$(
        kubectl get pods -n "$NAMESPACE" \
            -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' 2>/dev/null |
            grep -m1 "^${POD_QUERY}" || true
    )"

    if [[ -z "$POD_NAME" ]]; then
        echo "No pod found matching: $POD_QUERY (ns: $NAMESPACE)" >&2
        return 1
    fi

    echo "Using namespace: $NAMESPACE"
    echo "Using pod: $POD_NAME"
    echo "Copying: $REMOTE_PATH -> $LOCAL_PATH"

    kubectl cp -n "$NAMESPACE" "${POD_NAME}:${REMOTE_PATH}" "$LOCAL_PATH"
}

pod_ls() {
    local NAMESPACE="${1:-}"
    local POD_QUERY="${2:-}"
    local REMOTE_PATH="${3:-.}"

    if [[ -z "$NAMESPACE" || -z "$POD_QUERY" ]]; then
        echo "Usage: pod_ls <namespace> <pod-name-or-prefix> [remote-path]" >&2
        return 1
    fi

    local POD_NAME
    POD_NAME="$(
        kubectl get pods -n "$NAMESPACE" \
            -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' 2>/dev/null |
            grep -m1 "^${POD_QUERY}" || true
    )"

    if [[ -z "$POD_NAME" ]]; then
        echo "No pod found matching: $POD_QUERY (ns: $NAMESPACE)" >&2
        return 1
    fi

    echo "Using namespace: $NAMESPACE"
    echo "Using pod: $POD_NAME"
    echo "Listing: $REMOTE_PATH"

    kubectl exec -n "$NAMESPACE" "$POD_NAME" -- ls -lah "$REMOTE_PATH"
}

data_get() {
    local DATA_PATH="${1:-}"
    local LOCAL_PATH="${2:-.}"

    if [[ -z "$DATA_PATH" ]]; then
        echo "Usage: data_get <path-inside-/data> [local-path]" >&2
        return 1
    fi

    pod_get \
        "modhydro-dataobs" \
        "modhydro-dataobs" \
        "${DATA_PATH}" \
        "$LOCAL_PATH"
}

data_ls() {
    local DATA_PATH="${1:-}"

    DATA_PATH="${DATA_PATH#/}"

    pod_ls \
        "modhydro-dataobs" \
        "modhydro-dataobs" \
        "${DATA_PATH}"
}

csvview() {
    local sep="${2:-,}"

    sed -e "s/${sep}${sep}/${sep} ${sep}/g" "$1" |
        column -s "$sep" -t |
        less -#5 -N -S
}
