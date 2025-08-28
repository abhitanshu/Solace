Feature: Set Participation Structure and Retention Percentage for Agreement
  Scenario:
    # Create placement settings
    Given  url baseUrl+'/exposures/'+exposureId
    And request {"participationStructure": "FIXED_AMOUNT","retentionPercentage": 10}
    When method PATCH
    Then status 200
