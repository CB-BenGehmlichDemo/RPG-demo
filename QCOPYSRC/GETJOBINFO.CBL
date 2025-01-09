
       dcl-pr getJobInformation extpgm('QUSRJOBI');
         receiver char(32767) options(*varsize);
         receiverLength int(10) const;
         formatName char(8) const;
         qualifiedJobName char(26) const;
         internalJobIdentifier char(16) const;
         apiError char(32767) options(*nopass:*varsize);
         resetPerformanceStatistics char(1) const options(*nopass);
       end-pr;

