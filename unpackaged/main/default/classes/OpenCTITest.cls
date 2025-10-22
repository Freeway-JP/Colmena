@isTest 
public class OpenCTITest {

  
    @isTest
    static void testGetContactIdNoMatch() {
        


        PageReference pageRef = Page.IVRCall; 
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('sfdcIframeOrigin','https://colmenaseguros--devcrm2--c.sandbox.vf.force.com/');
        ApexPages.currentPage().getParameters().put('ANI','3152854092');
        ApexPages.currentPage().getParameters().put('UCID','00001099761698704595');
        ApexPages.currentPage().getParameters().put('DNIS','1120244');
        ApexPages.currentPage().getParameters().put('UUI','1,6547892310,0,1,001O800001WUTDIIA5,ABCDEFGHIJKLMNOPQR,2024/05/09 17:44:30,S');
        
        OpenCTI controller = new OpenCTI();
        String result = controller.getContactId('9999999999');
        System.assertEquals('', result);
        
        PageReference loadData = controller.loadData();
        PageReference redirect = controller.redirect();
        
    }

}