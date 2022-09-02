
export interface checkInSiteAccessType {
    CheckInId: string;
    Site: string;
    SiteTxt: string;
}

export interface checkInType {
    Id: string;
    CheckInId?: string;
    IsActiveEntity: boolean;
    _checkInSiteAccess?: checkInSiteAccessType[];

}

export default class CheckInService extends BaseService {


    public async DisableCheckinDraft(checkin: checkInType) {


        let checkInBinding = this.model.bindContext(`/checkIn(Id=${checkin.Id},IsActiveEntity=false)`, null, { $expand: `_checkInSiteAccess` });
        const checkinContext = this.model.bindContext("com.sap.gateway.srvd.zz_hr_checkin_v2.v0001.generateWindowsUserName_act(...)", checkInBinding.getBoundContext(), null)

        await checkinContext.getParameterContext().setProperty("PreserveChanges", true);
        return checkinContext.execute().then(() => {
            this.model.refresh();
            //do something
        }, (oError) => {
            debugger;
        }
        );
    }




}
