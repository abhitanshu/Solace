@Smoke
#  Below is the List of URLs to be checked as part of Health check activity -
#        Backend: https://app-dev-aggregator-backend.azurewebsites.net/api/v1/health
#        Frontend: https://app-dev-aggregator-frontend.azurewebsites.net/health
#        ODS: https://fapp-dev-aggregator-ods.azurewebsites.net/api/health
#        SP (Integration function app): https://fapp-dev-aggregator-to-platform.azurewebsites.net/api/health
#  To check from laptop -
#        Frontend: https://dev.solace-aggregator.rabobank.com/health
#        Backend: https://dev.solace-aggregator.rabobank.com/api/v1/health

Feature: Platform Smoke Test
  Scenario: Check Health Check endpoints
    Given  url healthUrl
    When method GET
    Then status 200