@Guarantor @Platform
Feature: Test Guarantor Endpoints

  Background:
    * call read('classpath:features/common/Background.feature')

  Scenario: Verify Create, Update, Delete and Get Endpoints for Guarantor

    # Create Guarantor
    Given  url baseUrl+'/guarantors'
    * set createGuarantorPayload.parentCompany.name = "MunichRe"
    And request createGuarantorPayload
    When method POST
    Then status 201
    And match $.isActive == true
    * def guarantorId = $.id

    # Create Guarantor
    Given  url baseUrl+'/guarantors'
    * set createGuarantorPayload.parentCompany.name = "MunichRe"
    And request createGuarantorPayload
    When method POST
    Then status 201
    And match $.isActive == true
    * def guarantorId = $.id

    # Read Guarantor
    Given  url baseUrl+'/guarantors/'+guarantorId
    When method GET
    Then status 200

    # Update Guarantor - with valid values for parent company name abd branch name
    Given  url baseUrl+'/guarantors/'+guarantorId
    * set createGuarantorPayload.parentCompany.name = "SwissRe"
    * set createGuarantorPayload.branch.name = "Geneva"
    And request createGuarantorPayload
    When method PUT
    Then status 200
    And match $.parentCompany.name == "SwissRe"
    And match $.branch.name == "Geneva"
    And match $.isActive == true

   # Update Guarantor - Branch could be null
    Given  url baseUrl+'/guarantors/'+guarantorId
    * set createGuarantorPayload.parentCompany.name = "SwissRe"
    * set createGuarantorPayload.branch = null
    And request createGuarantorPayload
    When method PUT
    Then status 200
    And match $.parentCompany.name == "SwissRe"
    And match $.branch == null
    And match $.isActive == true


    # Delete Guarantor
    Given  url baseUrl+'/guarantors/'+guarantorId
    When method DELETE
    Then status 200
    And match $.isActive == false

  Scenario Outline: Verify Errors when mandatory fields are missing
    Given  url baseUrl+'/guarantors'
    * set createGuarantorPayload.<field> = <value>
    * set createGuarantorPayload.<field> = <value>
    And request createGuarantorPayload
    When method POST
    Then status 400
    And match $.subErrors[0].field == "<field>"
    And match $.subErrors[0].message == "This field is required"
    Examples:
      | field              | value |
      | parentCompany.name | null  |
      | branch.name        | null  |
      | parentCompany.name | ""    |
      | branch.name        | ""    |

  Scenario: Assign Limits to Guranator and check Sorting
    #This test Create 4 obligors, 3 of them are for Ireland and 1 for Singapore
    #Test make sures that both countries and obligors are sorted correctly.
    #In PUT call we are sending Singapore first and then Ireland with obligors starting with C,B and A respectively
    #In response, it should return Ireland first with obligors starting with A,B and C respectively.Scenario:

    * def obligorA = "A"+testUtil.getRandomString(8)
    * def obligorB = "B"+testUtil.getRandomString(8)
    * def obligorC = "C"+testUtil.getRandomString(8)
    * def obligorD = "D"+testUtil.getRandomString(8)

    #Create Obligor 1
    Given  url baseUrlLimitMgmt+'/obligors'
    And request createObligorPayload
    And set createObligorPayload.name = obligorC
    And set createObligorPayload.countryCode = "IE"
    When method POST
    Then status 201
    And match $.name == obligorC
    * def obligorId1 = $.id

    #Create Obligor 2
    Given  url baseUrlLimitMgmt+'/obligors'
    And request createObligorPayload
    And set createObligorPayload.name = obligorB
    And set createObligorPayload.countryCode = "IE"
    When method POST
    Then status 201
    And match $.name == obligorB
    * def obligorId2 = $.id

    #Create Obligor 3
    Given  url baseUrlLimitMgmt+'/obligors'
    And request createObligorPayload
    And set createObligorPayload.name = obligorA
    And set createObligorPayload.countryCode = "IE"
    When method POST
    Then status 201
    And match $.name == obligorA
    * def obligorId3 = $.id

    #Create Obligor 4
    Given  url baseUrlLimitMgmt+'/obligors'
    And request createObligorPayload
    And set createObligorPayload.name = obligorD
    And set createObligorPayload.countryCode = "SG"
    When method POST
    Then status 201
    And match $.name == obligorD
    * def obligorId4 = $.id


    Given  url baseUrlLimitMgmt+'/countries?onlyWithObligors=true'
    When method GET
    Then status 200
    * def elements = response.elements
    * def JsonParser = Java.type('util.JsonParser')
    * def idIreland = JsonParser.getIdByCode(elements, 'IE')
    * def idSingapore = JsonParser.getIdByCode(elements, 'SG')

    # Create Guarantor
    Given  url baseUrl+'/guarantors'
    * set createGuarantorPayload.parentCompany.name = "MunichRe"
    And request createGuarantorPayload
    When method POST
    Then status 201
    And match $.isActive == true
    * def guarantorId = $.id

    Given url baseUrlLimitMgmt+'/limits/'+guarantorId
    And request createGuarantorLimitPayload
    And set createGuarantorLimitPayload[0].countryId = idSingapore
    And set createGuarantorLimitPayload[1].countryId = idIreland
    And set createGuarantorLimitPayload[0].linkedObligorLimits[0].obligorId = obligorId4
    And set createGuarantorLimitPayload[1].linkedObligorLimits[0].obligorId = obligorId1
    And set createGuarantorLimitPayload[1].linkedObligorLimits[1].obligorId = obligorId2
    And set createGuarantorLimitPayload[1].linkedObligorLimits[2].obligorId = obligorId3
    When method PUT
    Then status 200

    Given url baseUrlLimitMgmt+'/limits/'+guarantorId
    When method GET
    Then status 200
    And match response[0].countryId == idIreland
    And match response[1].countryId == idSingapore

    And match response[0].linkedObligorLimits[0].obligorId == obligorId3
    And match response[0].linkedObligorLimits[1].obligorId == obligorId2
    And match response[0].linkedObligorLimits[2].obligorId == obligorId1
    And match response[1].linkedObligorLimits[0].obligorId == obligorId4


    #  Delete the Obligor 1 created in Post call (Soft delete)
    Given  url baseUrlLimitMgmt+'/obligors/'+obligorId1
    When method DELETE
    Then status 200

    #  Delete the Obligor 2 created in Post call (Soft delete)
    Given  url baseUrlLimitMgmt+'/obligors/'+obligorId2
    When method DELETE
    Then status 200

    #  Delete the Obligor 3 created in Post call (Soft delete)
    Given  url baseUrlLimitMgmt+'/obligors/'+obligorId3
    When method DELETE
    Then status 200

    #  Delete the Obligor 4 created in Post call (Soft delete)
    Given  url baseUrlLimitMgmt+'/obligors/'+obligorId4
    When method DELETE
    Then status 200
