# General Bash Completion
if [ -f /etc/bash_completion ]; then
    source /etc/bash_completion
fi

if [ -f /usr/share/bash-completion/bash_completion ]; then
    source /usr/share/bash-completion/bash_completion
fi

# Git
if [ -f /usr/share/bash-completion/completions/git ]; then
    source /usr/share/bash-completion/completions/git
fi

# Terraform
if command -v terraform >/dev/null 2>&1; then
    complete -C terraform terraform
fi

# kubectl
if command -v kubectl >/dev/null 2>&1; then
    source <(kubectl completion bash)
fi

# Helm
if command -v helm >/dev/null 2>&1; then
    source <(helm completion bash)
fi

# Docker
if command -v docker >/dev/null 2>&1; then
    source <(docker completion bash)
fi

# AWS
if command -v aws_completer >/dev/null 2>&1; then
    complete -C "$(which aws_completer)" aws
fi

# Argo CD
if command -v argocd >/dev/null 2>&1; then
    source <(argocd completion bash)
fi

tree() {
    MSYS_NO_PATHCONV=1 tree.com "$(cygpath -w "$PWD")" /F /A
}
