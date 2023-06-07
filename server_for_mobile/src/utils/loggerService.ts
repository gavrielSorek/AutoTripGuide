// loggerService.ts
import { createLogger, format, transports } from 'winston';

export const logger = createLogger({
  transports: [
    new transports.File({ filename: 'combined.log' }),
    new transports.Console()
  ],
  format: format.combine(
    format.colorize(),
    format.timestamp(),
    format.printf(({ timestamp, level, message }) => {
      return `[${timestamp}] ${level}: ${message}`;
    })
  ),
});
