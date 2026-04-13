import 'dotenv/config';
import { WebSocketServer } from 'ws';

const PORT = Number(process.env.PORT ?? 8080);

// TODO(B1): wire up room manager, matchmaking queue, game engine
// TODO(B1): attach WS message router (see src/ws/router.ts)
// TODO(B1): initialize Sentry + pino logger
// TODO(B6): health check endpoint + graceful shutdown

const wss = new WebSocketServer({ port: PORT });

wss.on('connection', (socket) => {
  socket.on('message', (data) => {
    // Placeholder echo until the protocol router is wired up.
    socket.send(data.toString());
  });
});

// eslint-disable-next-line no-console
console.log(`[tichu-cyprus-server] listening on ws://localhost:${PORT}`);
