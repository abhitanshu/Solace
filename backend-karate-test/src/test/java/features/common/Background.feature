Feature: Background Steps for SDA Backend test cases

  Background:
    * def testUtil = Java.type('util.KarateTestUtil')
    # Define the payload Json files for all the API calls
    * def createAgreementPayload = read('classpath:resources/TestData/CreateAgreement.json')
    * def createGuarantorPayload = read('classpath:resources/TestData/CreateGuarantor.json')
    * def createPlacementPayload = read('classpath:resources/TestData/CreatePlacement.json')
    * def updatePlacementPayload = read('classpath:resources/TestData/UpdatePlacement.json')
    * def createObligorPayload = read('classpath:resources/TestData/CreateObligor.json')
    * def createGuarantorLimitPayload = read('classpath:resources/TestData/CreateGuarantorLimit.json')
    * def obligorName = testUtil.getRandomString(8)

  Scenario: