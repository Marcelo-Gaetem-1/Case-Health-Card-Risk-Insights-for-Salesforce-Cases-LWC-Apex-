public with sharing class CaseHealthService {

    public class CaseHealthDTO {
        @AuraEnabled public Id caseId;
        @AuraEnabled public String caseNumber;
        @AuraEnabled public String priority;
        @AuraEnabled public String status;
        @AuraEnabled public Datetime createdDate;
        @AuraEnabled public Decimal ageHours;
        @AuraEnabled public Integer ownerChanges;
        @AuraEnabled public Integer statusChanges;
        @AuraEnabled public Decimal riskScore;
        @AuraEnabled public String riskLevel;
    }
    
    @AuraEnabled
    public static void updateCaseRisk(Id caseId) {
        CaseHealthDTO dto = getCaseHealth(caseId);

        Case c = [
            SELECT Id, Risk_Score__c, Risk_Level__c
            FROM Case
            WHERE Id = :caseId
            LIMIT 1
        ];

        c.Risk_Score__c = dto.riskScore;
        c.Risk_Level__c = dto.riskLevel;

        update c;
    }

    @AuraEnabled(cacheable=true)
    public static CaseHealthDTO getCaseHealth(Id caseId) {

        Case c = [
            SELECT Id, CaseNumber, Priority, Status, CreatedDate
            FROM Case
            WHERE Id = :caseId
            LIMIT 1
        ];

        CaseHealthDTO dto = new CaseHealthDTO();
        dto.caseId = c.Id;
        dto.caseNumber = c.CaseNumber;
        dto.priority = String.valueOf(c.Priority);
        dto.status = String.valueOf(c.Status);
        dto.createdDate = c.CreatedDate;

        dto.ageHours = (Datetime.now().getTime() - c.CreatedDate.getTime()) / (1000 * 60 * 60);

        List<CaseHistory> history = [
            SELECT Field, OldValue, NewValue
            FROM CaseHistory
            WHERE CaseId = :c.Id
        ];

        Integer ownerChanges = 0;
        Integer statusChanges = 0;

        for (CaseHistory h : history) {
            if (h.Field == 'Owner') {
                ownerChanges++;
            } else if (h.Field == 'Status') {
                statusChanges++;
            }
        }

        dto.ownerChanges = ownerChanges;
        dto.statusChanges = statusChanges;

        Decimal score = 0;

        if (c.Priority == 'High') score += 40;
        else if (c.Priority == 'Medium') score += 20;

        score += (dto.ageHours / 2);
        score += (ownerChanges * 10);
        score += (statusChanges * 5);

        dto.riskScore = score;

        if (score >= 70) dto.riskLevel = 'High';
        else if (score >= 40) dto.riskLevel = 'Medium';
        else dto.riskLevel = 'Low';

        return dto;
    }
}
