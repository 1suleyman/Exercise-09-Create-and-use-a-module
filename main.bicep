@description('The Azure region into which the resources should be deployed.')
param location string = 'westus'

@description('The name of the App Service app.')
param appServiceAppName string = 'toy-${uniqueString(resourceGroup().id)}'

@description('The name of the App Service plan SKU.')
param appServicePlanSkuName string = 'F1'

@description('Indicates whether a CDN should be deployed.')
param deployCdn bool = true

var appServicePlanName = 'toy-product-launch-plan'

module app 'modules/app.bicep' = { // brings in the app module
  name: 'toy-launch-app' 
  params: { 
    appServiceAppName: appServiceAppName 
    appServicePlanName: appServicePlanName
    appServicePlanSkuName: appServicePlanSkuName
    location: location
  }
}
// what's happening is that the module is being called and the parameters are being passed to it

module cdn 'modules/cdn.bicep' = if (deployCdn) {
  name: 'toy-launch-cdn'
  params: {
    httpsOnly: true
    originHostName: app.outputs.appServiceAppHostName
  }
}
// The CDN module is only deployed if deployCdn is true

@description('The host name to use to access the website.')
output websiteHostName string = deployCdn ? cdn.outputs.endpointHostName : app.outputs.appServiceAppHostName
