## Curl timeout for MassIVE downloads.
MASSIVE_TIMEOUT <- getOption("MASSIVE_TIMEOUT", default = 3000L)

## SSL options for FTP connection
SSL_OPTS <- list(use_ssl = 3L, ftp_use_epsv = 1L, ssl_verifypeer = 0L,
                    ssl_verifyhost = 0L, connecttimeout = 30L,
                    timeout = MASSIVE_TIMEOUT)
