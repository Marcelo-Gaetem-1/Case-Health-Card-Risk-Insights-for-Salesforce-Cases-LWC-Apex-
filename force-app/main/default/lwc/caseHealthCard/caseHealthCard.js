import { LightningElement, api, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';

import getCaseHealth from '@salesforce/apex/CaseHealthService.getCaseHealth';
import updateCaseRisk from '@salesforce/apex/CaseHealthService.updateCaseRisk';

export default class CaseHealthCard extends LightningElement {
    @api recordId;

    data;
    error;
    wiredResult;

    @wire(getCaseHealth, { caseId: '$recordId' })
    wiredCaseHealth(result) {
        this.wiredResult = result;

        const { data, error } = result;

        if (data) {
            this.data = data;
            this.error = undefined;
        } else if (error) {
            this.error = error.body ? error.body.message : 'Unknown error';
            this.data = undefined;
        }
    }

    handleRefresh() {
        refreshApex(this.wiredResult);
    }

    handleSaveRisk() {
        updateCaseRisk({ caseId: this.recordId })
            .then(() => refreshApex(this.wiredResult))
            .then(() => {
                getRecordNotifyChange([{ recordId: this.recordId }]);

                this.dispatchEvent(new ShowToastEvent({
                    title: 'Success',
                    message: 'Risk information saved to Case.',
                    variant: 'success'
                }));
            })
            .catch(error => {
                const message = error?.body?.message || 'Unknown error';

                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error saving risk',
                    message: message,
                    variant: 'error'
                }));
            });
    }
}
