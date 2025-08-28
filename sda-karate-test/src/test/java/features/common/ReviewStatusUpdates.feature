Feature: Review Status Update

  Scenario:
    * configure headers = { "X-API-Key": #(importKey) }
    Given  url baseUrl+'/review_status_updates'
    And header Authorization = notification.authorization_header
    And request CreateReviewStatusUpdatePayload
    And set CreateReviewStatusUpdatePayload.calculation_period_id = calculationPeriodId
    And set CreateReviewStatusUpdatePayload.status = checkerReview.status
    When method POST
    Then status 201
    And match $.calculation_period_id == calculationPeriodId
    And match $.status == checkerReview.status
