
       dcl-pr deleteUserSpace extpgm('QUSDLTUS');
         qualifiedUserSpaceName char(20) const;
         apiError char(32767) options(*varsize);
       end-pr;

