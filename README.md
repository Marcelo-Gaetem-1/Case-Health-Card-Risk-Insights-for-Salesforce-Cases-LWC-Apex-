# Case Health Card – LWC for Case Risk Insights

This project contains a custom Lightning Web Component that provides a quick “health summary” for Salesforce Case records.  
The component calculates and displays metrics such as Case age, owner/status changes, and a dynamic risk score with a corresponding risk level.  
It also allows saving these calculated values back to the Case.

---

## Features

### Case Insights (Read-Only)
The component shows key Case indicators directly on the record page:

- Case Priority  
- Case Status  
- Case Age (hours)  
- Number of Owner changes  
- Number of Status changes  
- Calculated Risk Score  
- Assigned Risk Level (Low / Medium / High)

### Manual Refresh
A Refresh button retrieves the latest values from the server using `refreshApex`.

### Save Risk to Case
A “Save Risk to Case” button writes the calculated score and level to the fields:

- `Risk_Score__c`  
- `Risk_Level__c`

After saving, the UI updates immediately with `getRecordNotifyChange`.

---

## Risk Score Logic

The risk score is based on a simple formula customizable in the Apex class:

- Priority  
  - High = +40  
  - Medium = +20  
- Age  
  - +1 point for every 2 hours  
- Owner changes  
  - +10 each  
- Status changes  
  - +5 each  

Risk Level is assigned as:

- **High**: score ≥ 70  
- **Medium**: score ≥ 40  
- **Low**: otherwise

---

## Technical Overview

### Tech Stack
- Lightning Web Components (LWC)  
- Apex Classes  
- SOQL  
- Lightning Data Service (`getRecordNotifyChange`)  
- `refreshApex`  
- SLDS styling  

### Structure

