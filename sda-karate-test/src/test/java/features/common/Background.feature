Feature: Background Steps for SDA Backend test cases

  Background:
    * def createObligorPayload = read('classpath:resources/TestData/CreateObligor.json')
    * def createContractPayload = read('classpath:resources/TestData/CreateContract.json')
    * def createAvailmentPayload = read('classpath:resources/TestData/CreateAvailment.json')
    * def createUcpAgreementPayload = read('classpath:resources/TestData/CreateUcpAgreement.json')
    * def updateUcpAgreementPayload = read('classpath:resources/TestData/UpdateUcpAgreement.json')
    * def createAnnexByContractPayload = read('classpath:resources/TestData/CreateAnnexByContract.json')
    * def createAnnex2ByContractPayload = read('classpath:resources/TestData/CreateAnnex2ByContract.json')
    * def createAnnexAmendmentByContractPayload = read('classpath:resources/TestData/CreateAnnexAmendmentByContract.json')
    * def createAnnexAmendmentSameDayPayload = read('classpath:resources/TestData/CreateAnnexAmendmentSameDay.json')
    * def createRenumerationFeesBpsPayload = read('classpath:resources/TestData/CreateRenumerationFeesBps.json')
    * def createNotificationsPayload = read('classpath:resources/TestData/CreateNotifications.json')
    * def CreateReviewStatusUpdatePayload = read('classpath:resources/TestData/CreateReviewStatusUpdate.json')
    * def sendCalculationPeriodIdPayload = read('classpath:resources/TestData/SendCalculationPeriodId.json')
    * def createAvailmentPayloadAmnd = read('classpath:resources/TestData/CreateAvailment_Amnd.json')
    * def createAvailmentPayloadClos = read('classpath:resources/TestData/CreateAvailment_Clos.json')


    * def testUtil = Java.type('util.KarateTestUtil')
    * def obligorNum = testUtil.getRandomObligerNumber()
    * def contractCode = testUtil.getRandomContractCode(16)
    * def ucpId = testUtil.generateUUId()
    * def ucpId2 = testUtil.generateUUId()
    * def annexId = testUtil.generateUUId()
    * def annexId2 = testUtil.generateUUId()
    * def annexIdAmendment = testUtil.generateUUId()
    * def idRemuneration = testUtil.generateUUId()
    * def idRemuneration2 = testUtil.generateUUId()
    * def idRemunerationAmendment = testUtil.generateUUId()
    #participationReferenceNumber is not unique but using a different reference number for each request for convenience in debugging
    * def participationReferenceNumber = testUtil.getRandomString(10)
    * def currentDate = testUtil.getCurrentDate()

  Scenario:
