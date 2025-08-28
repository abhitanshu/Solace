Feature: Store Fee Calculations

  Scenario:
    * configure headers = { "X-API-Key": #(importKey) }
    Given  url baseUrl+'/remuneration_fee_calculations'
    And request sendCalculationPeriodIdPayload
    And set sendCalculationPeriodIdPayload.calculation_period_id = calculationPeriodId
    When method POST
    Then status 201
