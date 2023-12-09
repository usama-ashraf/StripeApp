# Rails Stripe Integration Application

## Overview
This Rails application is developed to demonstrate the integration with Stripe for payment processing. It features a `StripeService` for managing charges and refunds, and a `WebhooksController` to handle Stripe webhook events.

## Prerequisites
- Ruby (version as per `3.2.2`)
- Rails
- PostgreSQL OR sqlite3

## Setup Instructions

bundle install

rails db:create

rails db:migrate


### Configuring Stripe API Keys
1. Set environment variables for Stripe API keys. Use a file like `.env` in the root directory:


    STRIPE_SECRET_KEY=your_stripe_secret_key
    STRIPE_WEBHOOK_SECRET=your_stripe_webhook_secret

### Running the Application


    rails server

### Testing
### Running Tests with RSpec

    bundle exec rspec
