<Msg MessageType="515" DTCControlNumber="195168793" CancelIndicator="NEWM" DTCDate="20131210" DTCTime="154452" UpdateIndicator="TRAD" LinkedTransaction515="515" _515LinkedReference2="" _515LinkedReference3="344E26165629" PartialFillQuantity="" PartialQuantityType="" NetPriceISOCode="" NetPrice="" PriceIndicator="" TradeDate="20131210" SettlementDate="20131211" PriceISOCode="USD" Price="96.751000" PlaceOfTrade="0013" SourceDestinationISOCode="USD" TradeAmount="2443184.72" TransactionCode="SELL" DTCEligInd="DEI0" EligReasonCode1="" PayMethInd="APMT" SettleOptionInd="SOP0" InsBIC="HOINUS31A01" InsDTC="00040596" PortfolioCode="" ClearingBrokerBIC="BEARUS33XXX" ClearingBrokerDTCId="00000352" ClearingBrokerAccount="" ExecutingBrokerDTCId="00054454" LongShortIndicator="OTHR" ExecutingBrokerAccount="8801277693" ConfirmDate="20131210" ConfirmTime="154452" FXReferenceNo="A/C AUSA HCM" RoleIndicator="PRIN" AffirmPartyAltDesg="BOTH" Quantity="2500000.00000" QuantityType="FAMT" SecuritySymbolScheme="US" SecuritySymbol="3137EADB2" SecurityDescription1="02.375FMNT220113BE FIXED RATE" SecurityDescription2="" SecurityDescription3="" SecurityFormCode="" MaturityDate="20220113" AccrualDate="" InterestRate="2.375" FIANDescription1="GRBS REF   131210 G3540" FIANDescription2="" FIANDescription3="" FIANDescription4="" FIANDescription5="" SecurityType="FMT" AmortAccretFactor="" SecDescType="3" AdviceCanCorrDate="20131210" LegalStatus="0" PaymentStatus="0" BondTypeCode="0" BasisIndicator="0" ResultIndicator="00" InterestPaymentDate="" OptionCallInd="00" CallPutFeatureInd="0" PutBondType="00" BondFormCode="" IntPaymentFreq="0" SpecialCouponInd="0" FlatDefaultStatus="0" TaxStatus="0" SubjFedTax="" AltMinTax="" TrdInsProcNar1="GRBS REF   131210-G3540" TrdInsProcNar2="SUBJECT TO FAILS TRADING" TrdInsProcNar3="PRACTICE PUBLISHED BY TMPG AND" TrdInsProcNar4="SIFMA, AS DESCRIBED IN NOTE S" TrdInsProcNar5="ON BACK." TrdInsProcNar6="DUE 01/13/2022     02.375" TrdInsProcNar7="INTEREST DATES JAN, JUL 13" TrdInsProcNar8="YIELD2.827   TO MATURITY" TradeIndicator="TRAD" SettleCode1="" SIDIndicator="BRKR" BrokSettleBIC="FRNYUS33XXX" AffirmingParty="NAFT" InsBIC2="HOINUS31A01" InsDTCId2="00040596" InsAccount="" DeliverAgentBIC="CNORUS44XXX" DeliverAgentDTCId="00020290" ReceiverAgentBIC="" ReceiverAgentDTCId="" DeliverAgentAccount="22-73434" ReceiverAgentAccount="" DeliverClearingAgentDTCId="00002669" ReceiverClearingAgentDTCId="" DeliverClearingAgentAccount="" AccruedInterestISOCode="USD" AccruedInterest="24409.72" PrincipalAmountISOCode="USD" PrincipalAmount="2418775.00" />

Violation of PRIMARY KEY constraint 'SRConfirmData_PK'. Cannot insert duplicate key in object 'dbo.SRConfirmData'. The duplicate key value is (195168793, NEWM).

Violation of PRIMARY KEY constraint 'SRConfirmData_PK'. Cannot insert duplicate key in object 'dbo.SRConfirmData'. The duplicate key value is (195168794, NEWM).

Violation of PRIMARY KEY constraint 'SRConfirmData_PK'. Cannot insert duplicate key in object 'dbo.SRConfirmData'. The duplicate key value is (339272168, NEWM).

Violation of PRIMARY KEY constraint 'SRConfirmData_PK'. Cannot insert duplicate key in object 'dbo.SRConfirmData'. The duplicate key value is (365508397, CANC).

 select * from dtcc_year_2013.dbo.SRConfirmData
 where DtcControlNumber = '339272168'
 
  select * from dtcc.dbo.SRConfirmData
 where DtcControlNumber = '339272168'
 
 --delete dtcc_year_2013.dbo.SRConfirmData
 --where DtcControlNumber = '195168794'

EXEC pMxDTSTransferArchive

 select * from dtcc_year_2013.dbo.SRConfirmData as b
 join dtcc.dbo.SRConfirmData as A
 on b.DtcControlNumber = a.DtcControlNumber