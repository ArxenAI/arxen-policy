package azure.storage.require_encryption_at_rest_test

import future.keywords.if
import future.keywords.in
import data.azure.storage.require_encryption_at_rest

# --- Deny: infrastructure encryption disabled ---
test_deny_infrastructure_encryption_disabled if {
    result := require_encryption_at_rest.deny with input as {
        "resource_changes": [{
            "name": "st-hipaa-prod",
            "type": "azurerm_storage_account",
            "change": {
                "after": {
                    "infrastructure_encryption_enabled": false,
                    "min_tls_version": "TLS1_2"
                }
            }
        }]
    }
    count(result) == 1
    result[_] contains "infrastructure_encryption_enabled must be true"
}

# --- Deny: infrastructure_encryption_enabled key absent ---
test_deny_infrastructure_encryption_absent if {
    result := require_encryption_at_rest.deny with input as {
        "resource_changes": [{
            "name": "st-hipaa-unset",
            "type": "azurerm_storage_account",
            "change": {
                "after": {
                    "min_tls_version": "TLS1_2"
                }
            }
        }]
    }
    count(result) == 1
    result[_] contains "infrastructure_encryption_enabled is not set"
}

# --- Deny: TLS version too old ---
test_deny_old_tls if {
    result := require_encryption_at_rest.deny with input as {
        "resource_changes": [{
            "name": "st-hipaa-prod",
            "type": "azurerm_storage_account",
            "change": {
                "after": {
                    "infrastructure_encryption_enabled": true,
                    "min_tls_version": "TLS1_0"
                }
            }
        }]
    }
    count(result) == 1
    result[_] contains "min_tls_version must be 'TLS1_2'"
}

# --- Deny: min_tls_version key absent ---
test_deny_min_tls_absent if {
    result := require_encryption_at_rest.deny with input as {
        "resource_changes": [{
            "name": "st-hipaa-unset",
            "type": "azurerm_storage_account",
            "change": {
                "after": {
                    "infrastructure_encryption_enabled": true
                }
            }
        }]
    }
    count(result) == 1
    result[_] contains "min_tls_version is not set"
}

# --- Deny: both violations present ---
test_deny_both_violations if {
    result := require_encryption_at_rest.deny with input as {
        "resource_changes": [{
            "name": "st-noncompliant",
            "type": "azurerm_storage_account",
            "change": {
                "after": {
                    "infrastructure_encryption_enabled": false,
                    "min_tls_version": "TLS1_1"
                }
            }
        }]
    }
    count(result) == 2
}

# --- Deny: both keys absent ---
test_deny_both_keys_absent if {
    result := require_encryption_at_rest.deny with input as {
        "resource_changes": [{
            "name": "st-minimal",
            "type": "azurerm_storage_account",
            "change": {
                "after": {}
            }
        }]
    }
    count(result) == 2
}

# --- Pass: compliant storage account ---
test_pass_compliant_storage if {
    result := require_encryption_at_rest.deny with input as {
        "resource_changes": [{
            "name": "st-hipaa-compliant",
            "type": "azurerm_storage_account",
            "change": {
                "after": {
                    "infrastructure_encryption_enabled": true,
                    "min_tls_version": "TLS1_2"
                }
            }
        }]
    }
    count(result) == 0
}
