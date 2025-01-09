
       dcl-pr getUserSpacePtr extpgm('QUSPTRUS');
         qualifiedUserSpaceName char(20) const;
         returnedPtr pointer;
         apiError char(32767) options(*nopass:*varsize);
       end-pr;

