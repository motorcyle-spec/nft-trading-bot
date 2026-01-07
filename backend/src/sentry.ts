import * as Sentry from '@sentry/node'

const SENTRY_DSN = process.env.SENTRY_DSN || ''

export function initializeSentry() {
  if (!SENTRY_DSN) {
    console.warn('Sentry DSN not configured')
    return
  }

  Sentry.init({
    dsn: SENTRY_DSN,
    tracesSampleRate: 1.0,
    environment: process.env.NODE_ENV || 'development',
  })
}

export function captureException(error: Error, context?: any) {
  Sentry.captureException(error, { extra: context })
}

export function captureMessage(message: string, level: Sentry.SeverityLevel = 'info') {
  Sentry.captureMessage(message, level)
}

export default Sentry
