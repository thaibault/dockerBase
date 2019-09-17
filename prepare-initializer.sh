#!/usr/bin/bash
# -*- coding: utf-8 -*-
# region convert strings into arrays
ENVIRONMENT_FILE_PATHS=($ENVIRONMENT_FILE_PATHS)
ENVIRONMENT_FILE_PATHS=($ENVIRONMENT_FILE_PATHS)
PASSWORD_FILE_PATHS=($PASSWORD_FILE_PATHS)
# endregion
# region choose initializer script
# We prefer the local mounted working copy managed initializer if available.
if [[ "$1" != '--no-check-local-initializer' ]]; then
    for file_path in "${ENVIRONMENT_FILE_PATHS[@]}"; do
        file_path="$(dirname "$file_path")/initialize.sh"
        if [ -s "$file_path" ]; then
            exec "$file_path" --no-check-local-initializer
        fi
    done
fi
# endregion
# region load dynamic environment variables
for file_path in "${ENVIRONMENT_FILE_PATHS[@]}"; do
    if [ -f "$file_path" ]; then
        source "$file_path"
    fi
done
# endregion
# region decrypt security related artefacts needed at runtime
if [[ "$DECRYPT" != false ]]; then
    for index in "${!ENCRYPTED_PATHS[@]}"; do
        if \
            [ -d "${ENCRYPTED_PATHS[index]}" ] && \
            [ -d "${DECRYPTED_PATHS[index]}" ]
        then
            if [ -s "${PASSWORD_FILE_PATHS[index]}" ]; then
                gocryptfs \
                    -allow_other \
                    -nonempty \
                    -passfile "${PASSWORD_FILE_PATHS[index]}" \
                    "${ENCRYPTED_PATHS[index]}" \
                    "${DECRYPTED_PATHS[index]}"
            else
                gocryptfs \
                    -allow_other \
                    -nonempty \
                    "${ENCRYPTED_PATHS[index]}" \
                    "${DECRYPTED_PATHS[index]}"
            fi
        fi
    done
fi
# endregion
# region vim modline
# vim: set tabstop=4 shiftwidth=4 expandtab:
# vim: foldmethod=marker foldmarker=region,endregion:
# endregion
