# Table of Contents

- [Table of Contents](#table-of-contents)
    - [Introduction](#introduction)
    - [Claim Elements](#claim-elements)
        - [UserData](#userdata)
        - [Hashes](#hashes)
    - [Authentication Workflows](#authentication-workflows)
    - [Possible Use Cases](#possible-use-cases)


## Introduction

The Claim module in combination with the Attestation Protocol enables the possibility to create [verifiable claims](https://docs.microsoft.com/en-us/previous-versions/msp-n-p/ff359101(v=pandp.10)?redirectedfrom=MSDN), backed by trusted authorities, and therefore to fully authenticate an entity to a third party. 

To protect privacy and shrink the size of attached data, the attached entity data aren't stored in clear text. Only the fingerprint (hash) of a data set is public available and stored on the blockchain. This lets an entity share pieces of attested user data in a way that the verify is able to validate these pieces without knowing the whole data set.

A claim based authentication system could be build based on these two modules.


## Claim Elements

A claim object, representing a claim, contains the following elements:

````typescript
// TypeScript notation
interface ClaimObject {
    userData: [
        {
            name: string;
            value: string;
            nonce: string;
        }
    ] | [], // empty array allowed
    hashes: {
        leafHashes: string[];
        rootHash: string;
    }
}
````


### UserData

The userData array contains the clear text user data. Each user data is bundled in an object with the following properties:

| Property |                    Description                    |
|----------|:-------------------------------------------------:|
| name     |                 the user data name                |
| value    |                the user data value                |
| nonce    | a unique, 64 characters long, alphanumeric string |

*user data object properties*

the **name** property contains the name of an user data. It can be a string of any kind. The **value** property contains the actual user data. The **nonce** is needed for unique leaf hash generation.


### Hashes

As described above, an entity/user should be able to create a claim with a subset of one's user data. To achieve this, a [hash tree](https://en.wikipedia.org/wiki/Merkle_tree) based on the user data is created an added to the claim.

To prevent an attacker from recreating the root hash based on collected data, every user data is appended with a unique nonce. This leads to different merkle roots even if two user data contain the same name and value.

A flat tree structure with an order of n and a depth of 2 should be used:

![](./.../../draw.io/out/diagrams-merkle-tree.svg)

*merkle tree based on user data with order n and depth 2*

Whenever an entity wants to authenticate itself, it shares the requested user data subset in clear text along with the necessary hashes to recreate the hash tree. A verifier then recreates the hash tree and compares the root hashes to verify the integrity of the shared data.

The hashes object bundles the necessary hashes to recreate the hash tree.

| Property   |              Description              |
|------------|:-------------------------------------:|
| leafHashes | the user data representing hash array |
| rootHash   |    the claim representing root hash   |

*hashes object properties*

The **leafHash** property holds the leaf hashes needed to recreate the root hash. A leaf hash is only included if the corresponding user data is not included in the user data array.

To gain consistency at the leaf hash creation process, every property of a user data object is first sorted alphanumeric based on the property key. The value of these properties are then concatenated to one utf8 string and finally hashed with the sha256 hash-function.

````typescript
/* User data object */
{
    name: 'user-data-name',
    value: 'user-data-value',
    nonce: 'EnYg7EpDzOSPJM3QVfi0DtKmgwiYX4slAv5zNPmenSXiM5PSPAz03PfNI5C1XEDV'
}


/* 1. Sort keys alphanumeric */
{
    name: 'user-data-name',
    nonce: 'EnYg7EpDzOSPJM3QVfi0DtKmgwiYX4slAv5zNPmenSXiM5PSPAz03PfNI5C1XEDV'
    value: 'user-data-value',
}


/* 2. Concatenate values */
'user-data-nameEnYg7EpDzOSPJM3QVfi0DtKmgwiYX4slAv5zNPmenSXiM5PSPAz03PfNI5C1XEDVuser-data-value'


/* 3. Convert string to utf8 and create leaf hash */
'4add21b3a1ed01e56594a1f32034de55be10d1b5f88dd3e6217a1ae51f344623'
````


The **root hash** property holds the claim representing root hash of the hash tree. It is also generated in a consistency way. After all leaf hashes are available, these hashes will be, similar to the leaf hash creation, first alphanumerically sorted and then concatenated. The resulting concatenation string is finally hashed (sha256) and the resulting hash string represents the root hash.

````typescript
/* Leaf hash array */
[
    '4add21b3a1ed01e56594a1f32034de55be10d1b5f88dd3e6217a1ae51f344623',
    '2062f74d687e4d8498116de9ea9a63f89b2b98b5442989c474088d27da618300',
    '783fd6868618d40f86aec0d3468fb15a1aa6464d0bd34eea9478b8d3637becd8',
    'e665592df0614a0c6d837145b94887ed80d450a365a46e93cfed00fca91ac54d',
]


/* 1. Sort leaf hashes alphanumeric */
[
    'e665592df0614a0c6d837145b94887ed80d450a365a46e93cfed00fca91ac54d',
    '2062f74d687e4d8498116de9ea9a63f89b2b98b5442989c474088d27da618300',
    '4add21b3a1ed01e56594a1f32034de55be10d1b5f88dd3e6217a1ae51f344623',
    '783fd6868618d40f86aec0d3468fb15a1aa6464d0bd34eea9478b8d3637becd8',
]


/* 2. Concatenate leaf hashes */
'e665592df0614a0c6d837145b94887ed80d450a365a46e93cfed00fca91ac54d2062f74d687e4d8498116de9ea9a63f89b2b98b5442989c474088d27da6183004add21b3a1ed01e56594a1f32034de55be10d1b5f88dd3e6217a1ae51f344623783fd6868618d40f86aec0d3468fb15a1aa6464d0bd34eea9478b8d3637becd8'


/* 3. Convert string to utf8 and create root hash */
'f35c8ac4a881987e38c84a336d91ff3039eeeac42d8bb5baa9dab6448c64fa46'
````


## Authentication Workflows

An authentication system would have the three following workflows to register, create and verify a verifiable claim.

![](./../plantUml/out/claim/../../../../plantUml/out/claim/claim-authentication-workflow/claim-authentication-workflow.svg)

*claim authentication workflows*


There are three major steps for a claim based authentication mechanism: claim registration, claim creation and claim verification.

The claim **registration process** register a claim to an account in the way that an attestor attests an account with the claims root hash as payload. This ensures that a claim is created and / or verified by a trusted entity.

An attested account holder can then **create** verifiable **claims** self sovereignly. One can decide which subset of registered claim user data one wants to share and a verifier can later verify the authenticity of this subset without knowing the whole registered claim data. To do so, one selects the user data to claim, creates the claim and signs it in the way described in the Attestation Protocol, where the payload contains the previous created claim.

The verifier then is able to **verify** the **claim** against the self created root hash (based on the claim user data and hashes) and the root hash attached to the claim creator account. If these hashes match, The same verification process comes into place as described in the Attestation Protocol. If the verification process succeed, the verifier can be sure that the claim is indeed signed by the claim creator account, the claim data are valid and attested by a trustworthy entity.


## Possible Use Cases

Because such an identifier, in the end, is an ordinary [asymmetric key pair](https://en.wikipedia.org/wiki/Public-key_cryptography), an entity can do all the things an asymmetric key pair provides, like encrypting messages, signing documents or authentication. 

- An entity could for example create its **own PKI** with the identifier acting as a root certificate and then has a system where even the trust root can be verified and validated.

- One could **sign documents** for ones customer where a third party can validate and verify that these documents are signed by this specific user.

- A **login system**, similar to [Facebook](https://developers.facebook.com/docs/facebook-login/) or [Google](https://developers.google.com/identity/sign-in/web/sign-in) Login could be developed where an entity can easily login with its identifier without revealing its private data and relying on a centralized infrastructure.
