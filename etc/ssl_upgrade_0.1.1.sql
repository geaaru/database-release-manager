-- $Id$ --

BEGIN TRANSACTION;

ALTER TABLE SslTunnels add COLUMN
  -- Identitfy if tunnel is socks (1) or not (0)
  socks_flag          INTEGER NOT NULL DEFAULT 0;

COMMIT;
