Feature: Get Payment Advice Pdf

  Scenario:
    * configure headers = { "X-API-Key": #(importKey) }
    Given  url baseUrl+'/payment_advice/'+paymentAdviceId+'/pdf'
    When method GET
    Then status 200
