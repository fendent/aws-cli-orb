PARAM_ROLE_SESSION_NAME=$(eval echo "${PARAM_ROLE_SESSION_NAME}")
PARAM_AWS_CLI_ROLE_ARN=$(eval echo "${PARAM_AWS_CLI_ROLE_ARN}")

if [ -z "${PARAM_ROLE_SESSION_NAME}" ]; then
    echo "Role session name is required"
    exit 1
fi

# shellcheck disable=SC2086,SC2034
read -r AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN <<<"$(aws sts assume-role-with-web-identity \
    --role-arn ${PARAM_AWS_CLI_ROLE_ARN} \
    --role-session-name ${PARAM_ROLE_SESSION_NAME} \
    --web-identity-token ${CIRCLE_OIDC_TOKEN} \
    --duration-seconds ${PARAM_SESSION_DURATION} \
    --query 'Credentials.[AccessKeyId,SecretAccessKey,SessionToken]' \
    --output text)"

if [ -z "${AWS_ACCESS_KEY_ID}" ] || [ -z "${AWS_SECRET_ACCESS_KEY}" ] || [ -z "${AWS_SESSION_TOKEN}" ]; then
    echo "Failed to assume role";
    exit 1
else 
    {
        echo "export AWS_ACCESS_KEY_ID=\"${AWS_ACCESS_KEY_ID}\""
        echo "export AWS_SECRET_ACCESS_KEY=\"${AWS_SECRET_ACCESS_KEY}\""
        echo "export AWS_SESSION_TOKEN=\"${AWS_SESSION_TOKEN}\""
    } >>"$BASH_ENV"
    echo "Assume role with web identity succeeded"
fi
