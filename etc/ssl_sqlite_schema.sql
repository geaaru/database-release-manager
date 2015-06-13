-- $Id$ --

BEGIN TRANSACTION;

CREATE TABLE SslTunnels (
  id_tunnel             INTEGER PRIMARY KEY AUTOINCREMENT,
  name                  TEXT NOT NULL,
  remote_host           TEXT NOT NULL,
  remote_port           INTEGER NOT NULL DEFAULT 0,
  tunnel_host           TEXT NOT NULL,
  tunnel_hport          INTEGER NOT NULL DEFAULT 0,
  tunnel_user           TEXT,
  -- Identitfy if tunnel is reverse (1) or not (0)
  reverse_flag          INTEGER NOT NULL DEFAULT 0,
  -- Identify local port binding
  local_port            INTEGER NOT NULL DEFAULT 0,
  -- Identify local host for reverse tunnel
  local_host            TEXT,
  -- Identify remote local port for reverse tunnel.
  remote_lport          INTEGER,

  CONSTRAINT uc_tun_name UNIQUE(name)
);

COMMIT;
