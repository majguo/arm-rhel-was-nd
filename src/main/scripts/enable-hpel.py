# Enable HPEL and disable RAS logging
HPELService = AdminConfig.getid("/Server:${WAS_SERVER_NAME}/HighPerformanceExtensibleLogging:/")
AdminConfig.modify(HPELService, "[[enable true]]")
RASLogging = AdminConfig.getid("/Server:${WAS_SERVER_NAME}/RASLoggingService:/")
AdminConfig.modify(RASLogging, "[[enable false]]")

# Save configuratoin changes
AdminConfig.save()
