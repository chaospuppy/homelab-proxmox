#!/bin/bash

# Certbot with Cloudflare DNS Script
# Generates and renews SSL certificates using certbot with Cloudflare DNS validation
# Requires: certbot and certbot-dns-cloudflare plugin

set -euo pipefail

# Configuration
CERTBOT_EMAIL="${CERTBOT_EMAIL:-your-email@example.com}"
CLOUDFLARE_CREDENTIALS_FILE="${CLOUDFLARE_CREDENTIALS_FILE:-/etc/letsencrypt/cloudflare.ini}"
CERT_DIR="${CERT_DIR:-/etc/letsencrypt/live}"
LOG_FILE="${LOG_FILE:-/var/log/certbot-cloudflare.log}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Error handling
error_exit() {
    echo -e "${RED}Error: $1${NC}" >&2
    log "ERROR: $1"
    exit 1
}

# Check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        error_exit "This script must be run as root"
    fi
}

# Check dependencies
check_dependencies() {
    log "Checking dependencies..."

    if ! command -v certbot &> /dev/null; then
        error_exit "certbot is not installed"
    fi

    if ! certbot plugins | grep -q "dns-cloudflare"; then
        error_exit "certbot-dns-cloudflare plugin is not installed"
    fi

    if [[ ! -f "$CLOUDFLARE_CREDENTIALS_FILE" ]]; then
        error_exit "Cloudflare credentials file not found: $CLOUDFLARE_CREDENTIALS_FILE"
    fi

    # Check credentials file permissions
    if [[ "$(stat -c %a "$CLOUDFLARE_CREDENTIALS_FILE")" != "600" ]]; then
        log "Setting correct permissions for credentials file"
        chmod 600 "$CLOUDFLARE_CREDENTIALS_FILE"
    fi

    log "All dependencies are satisfied"
}

# Generate new certificate
generate_certificate() {
    local domain="$1"
    local additional_domains="${2:-}"

    log "Generating certificate for domain: $domain"

    local cert_command="certbot certonly \
        --dns-cloudflare \
        --dns-cloudflare-credentials $CLOUDFLARE_CREDENTIALS_FILE \
        --email $CERTBOT_EMAIL \
        --agree-tos \
        --non-interactive \
        --expand \
        --domain $domain"

    # Add additional domains if provided
    if [[ -n "$additional_domains" ]]; then
        IFS=',' read -ra DOMAINS <<< "$additional_domains"
        for additional_domain in "${DOMAINS[@]}"; do
            cert_command+=" --domain $(echo "$additional_domain" | xargs)"
        done
    fi

    log "Executing: $cert_command"

    if eval "$cert_command"; then
        log "Certificate generated successfully for $domain"
        echo -e "${GREEN}Certificate generated successfully!${NC}"
        echo -e "Certificate location: ${GREEN}$CERT_DIR/$domain/${NC}"
    else
        error_exit "Failed to generate certificate for $domain"
    fi
}

# Renew certificates
renew_certificates() {
    log "Starting certificate renewal process"

    if certbot renew --dns-cloudflare --dns-cloudflare-credentials "$CLOUDFLARE_CREDENTIALS_FILE"; then
        log "Certificate renewal completed successfully"
        echo -e "${GREEN}Certificate renewal completed successfully!${NC}"
    else
        error_exit "Certificate renewal failed"
    fi
}

# List certificates
list_certificates() {
    log "Listing certificates"
    certbot certificates
}

# Create credentials file template
create_credentials_template() {
    local creds_file="$1"

    cat > "$creds_file" << EOF
# Cloudflare API credentials used by Certbot
# Option 1: API Token (Recommended)
dns_cloudflare_api_token = your_api_token_here

# Option 2: Global API Key + Email (Legacy)
# dns_cloudflare_email = your-email@example.com
# dns_cloudflare_api_key = your_global_api_key_here
EOF

    chmod 600 "$creds_file"
    echo -e "${YELLOW}Credentials template created at: $creds_file${NC}"
    echo -e "${YELLOW}Please edit this file with your actual Cloudflare credentials${NC}"
}

# Show usage
usage() {
    cat << EOF
Usage: $0 [COMMAND] [OPTIONS]

COMMANDS:
    generate <domain> [additional_domains]  Generate new certificate for domain
                                           Additional domains as comma-separated list
    renew                                  Renew all certificates
    list                                   List existing certificates
    create-template <file>                 Create credentials file template

EXAMPLES:
    $0 generate example.com
    $0 generate example.com "www.example.com,api.example.com"
    $0 renew
    $0 list
    $0 create-template /etc/letsencrypt/cloudflare.ini

ENVIRONMENT VARIABLES:
    CERTBOT_EMAIL                Email for certificate registration
    CLOUDFLARE_CREDENTIALS_FILE  Path to Cloudflare credentials file
    CERT_DIR                     Certificate directory
    LOG_FILE                     Log file path

EOF
}

# Main function
main() {
    # Create log directory if it doesn't exist
    mkdir -p "$(dirname "$LOG_FILE")"

    case "${1:-}" in
        "generate")
            check_root
            check_dependencies
            if [[ -z "${2:-}" ]]; then
                error_exit "Domain name required for generate command"
            fi
            generate_certificate "$2" "${3:-}"
            ;;
        "renew")
            check_root
            check_dependencies
            renew_certificates
            ;;
        "list")
            check_root
            list_certificates
            ;;
        "create-template")
            if [[ -z "${2:-}" ]]; then
                error_exit "File path required for create-template command"
            fi
            create_credentials_template "$2"
            ;;
        "help"|"-h"|"--help")
            usage
            ;;
        "")
            error_exit "No command specified. Use '$0 help' for usage information."
            ;;
        *)
            error_exit "Unknown command: $1. Use '$0 help' for usage information."
            ;;
    esac
}

# Run main function with all arguments
main "$@"
