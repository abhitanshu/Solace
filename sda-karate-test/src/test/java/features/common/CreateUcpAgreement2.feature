Feature: Create UCP Agreement

  Scenario:
    * configure headers = { "X-API-Key": #(eventsKey) }
    * def endDate = testUtil.getDateAfterSubtractingMonths(1)
    * def effectiveDate = testUtil.getDateAfterSubtractingMonths((data.month))

    Given  url baseUrl+'/ucp_agreements'
    And request createUcpAgreementPayload
    And header Authorization = notification.authorization_header
    And set createUcpAgreementPayload.ucp_id = ucpId2
    And set createUcpAgreementPayload.contract_code = contractCode
    And set createUcpAgreementPayload.obligor_number = obligorNum
    And set createUcpAgreementPayload.participation_reference_number = participationReferenceNumber
    And set createUcpAgreementPayload.currency = data.currency
    And set createUcpAgreementPayload.payment_schedule_frequency = data.paymentFrequency
    # set maturity date to current date and end date a month before
    And set createUcpAgreementPayload.maturity_date = data.maturityDate
#    And set createAnnexByContractPayload.end_date = endDate

    And set createUcpAgreementPayload.effective_date = effectiveDate
    And set createUcpAgreementPayload.end_date = currentDate

    And set createUcpAgreementPayload.created_at = "2023-05-20T00:00:00+00:00"


    When method POST
    Then status 201
    And match $.obligor_number == obligorNum
    And match $.contract_code == contractCode
    And match $.participation_reference_number == participationReferenceNumber
    And match $.ucp_id == ucpId2
