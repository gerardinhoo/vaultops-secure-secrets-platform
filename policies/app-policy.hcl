// Least Privilege Implementation
path "secret/data/app*" {
    capabilities = ["read"]
}