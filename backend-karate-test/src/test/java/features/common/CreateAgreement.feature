Feature: Test Agreement/Exposure Endpoints

  Background:
    * call read('classpath:features/common/Background.feature')

  Scenario: Verify Create, Update, Delete and Get Endpoints for Exposure
    #Create Obligor
    * call read('classpath:features/common/CreateObligor.feature')

    # Create Agreement
    Given  url baseUrl+'/exposures'
    And request createAgreementPayload
    And set createAgreementPayload.obligorId = obligorId
    When method POST
    Then status 201
    * def exposureId = $.id
