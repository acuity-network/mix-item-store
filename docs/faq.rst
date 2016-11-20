.. _faq:

##########################
Frequently asked questions
##########################

#. What happens if illegal content is stored in a BlobStore contract. Could node operators be liable for storing and transmitting such content?

   Additional smart contracts will be developed so that the community can collectively decide which blobs are breaking which laws. Node operators will then be able to use this information to delete transactions and logs.

|
#. If nodes use fast-sync they not store logs and therefore do not store blobs. Won't this prevent BlobStore from working?

   No - nodes serving light clients are financially incentivized to not use fast-sync because they get paid by the light client to retrieve logs. Older or less popular content may cost more to retrieve.
   
   The primary purpose of the Link blockchain is to store data in BlobStore, so it would not make much sense for Link nodes to use fast-sync.
