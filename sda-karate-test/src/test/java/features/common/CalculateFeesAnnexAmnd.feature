Feature: Calculate Fees

  Scenario:
    #Always take latest version of Annex(here version #2) for guarantor_participation_percentage
    * def feeCalculationAmount = createAnnex2ByContractPayload.guarantor_participation_percentage * 0.01 * createAvailmentPayload.outstanding_liability_amount
    * def feeCalculationAmountAmnd = createAnnex2ByContractPayload.guarantor_participation_percentage * 0.01 * createAvailmentPayloadAmnd.outstanding_liability_amount
    * def feeCalculationAmountAnnexAmnd = createAnnexAmendmentByContractPayload.guarantor_participation_amount

    * def daysInYear =
    """
      function() {
        if (createUcpAgreementPayload.currency == "GBP") {
            return 365;
        } else {
            return 360;
        }
      }
    """
    * def numberOfDays = testUtil.calculateDateDifference(effectiveDate,createAvailmentPayloadAmnd.day)
    * def numberOfDaysAmnd = testUtil.calculateDateDifference(createAvailmentPayloadAmnd.day,createAnnexAmendmentByContractPayload.created_at)
    * def numberOfDaysAnnexAmnd = testUtil.calculateDateDifference(createAnnexAmendmentByContractPayload.created_at,currentDate)

    * def expectedFees = Number((numberOfDays * feeCalculationAmount * calculatedBpsValue / 10000 / daysInYear()).toFixed(2))
    * print numberOfDays
    * print feeCalculationAmount

    * def expectedFeesAmnd = Number((numberOfDaysAmnd * feeCalculationAmountAmnd * calculatedBpsValue / 10000 / daysInYear()).toFixed(2))
    * print numberOfDaysAmnd
    * print feeCalculationAmountAmnd

    * def expectedFeesAnnexAmnd = Number((numberOfDaysAnnexAmnd * feeCalculationAmountAnnexAmnd * calculatedBpsValue / 10000 / daysInYear()).toFixed(2))
    * print numberOfDaysAnnexAmnd
    * print feeCalculationAmountAnnexAmnd

    * configure headers = { "X-API-Key": #(importKey) }

    Given  url baseUrl+'/calculate_fees?calculation_period_id='+calculationPeriodId
    When method GET
    Then status 200
    And match $[0].day_count == numberOfDays
    And match $[1].day_count == numberOfDaysAmnd
    And match $[2].day_count == numberOfDaysAnnexAmnd
    * def formatNumber = function(num) { return Number(num.toFixed(2)); }
    * def actualFees = formatNumber(response[0].amount)
    * def actualFeesAmnd = formatNumber(response[1].amount)
    * def actualFeesAnnexAmnd = formatNumber(response[2].amount)
    And match actualFees == expectedFees
    And match actualFeesAmnd == expectedFeesAmnd
    And match actualFeesAnnexAmnd == expectedFeesAnnexAmnd
