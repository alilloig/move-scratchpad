import { getFullnodeUrl, SuiClient } from '@mysten/sui/client';

const client = new SuiClient({
	url: getFullnodeUrl('localnet'),
});

const txn = await client.getObject({
	id: '0x08d78ce5e3b0b296f9a5a024864de757688f8ef1160bcb5320be5ace32c66b63',
	options: { 
        showContent: true 
    },
});

if (txn.data!.content!.dataType === "moveObject") {
    console.log(txn.data!.content!.fields);
    console.log((txn.data!.content!.fields as any).inner);
}