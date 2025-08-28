@Countries @Platform
Feature: Test Obligor and Country Endpoints
  Background:
    * call read('classpath:features/common/Background.feature')

  Scenario: Verify Create, Update, Delete and Get Endpoints for Obligor and Country

  #Create Obligor
    Given  url baseUrlLimitMgmt+'/obligors'
    And request createObligorPayload
    And set createObligorPayload.name = obligorName
    When method POST
    Then status 201
    And match $.name == obligorName
    * def obligorId = $.id

  # Get Obligor - Make sure both list and details work
    Given  url baseUrlLimitMgmt+'/obligors'
    When method GET
    Then status 200

    Given  url baseUrlLimitMgmt+'/obligors/'+obligorId
    When method GET
    Then status 200
    And match $.name == obligorName

  # Make sure there is only one obligor with country(Netherlands) which we created in previous post call
    Given  url baseUrlLimitMgmt+'/countries?onlyWithObligors=true'
    When method GET
    Then status 200
    * def elements = response.elements
    * def JsonParser = Java.type('util.JsonParser')
    * def idNetherlands = JsonParser.getIdByCode(elements, 'NL')
    * match idNetherlands != null


#  Delete the Obligor created in Post call (Soft delete)
    Given  url baseUrlLimitMgmt+'/obligors/'+obligorId
    When method DELETE
    Then status 200

  #There are total 249 countries supported, make sure GET call returns the correct count
    Given  url baseUrlLimitMgmt+'/countries?onlyWithObligors=false'
    When method GET
    Then status 200
    And match $.totalElements == 249

    Given  url baseUrlLimitMgmt+'/countries'
    When method GET
    Then status 200
    And match $.totalElements == 249
