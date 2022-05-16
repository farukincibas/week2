//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import { PoseidonT3 } from "./Poseidon.sol"; //an existing library to perform Poseidon hash on solidity
import "./verifier.sol"; //inherits with the MerkleTreeInclusionProof verifier contract

contract MerkleTree is Verifier {
    uint256[] public hashes; // the Merkle tree in flattened array form
    uint256 public index = 0; // the current index of the first unfilled leaf
    uint256 public root; // the current Merkle root

    constructor() {
               // [assignment] initialize a Merkle tree of 8 with blank leaves
        for (uint8 i = 0; i < 8; i++) {
            hashes.push(0);
        }
        uint8 n = 3;
        for (uint8 i = 0; i < 2**n - 2; i++) {
            hashes.push(
                PoseidonT3.poseidon([hashes[2 * i], hashes[2 * i + 1]])
            );
        }
    }

    function insertLeaf(uint256 hashedLeaf) public returns (uint256) {
               // [assignment] insert a hashed leaf into the Merkle tree
        uint256 n = 3;
        hashes[index] = hashedLeaf;
        for (uint256 i = n; i == 1; i--) {
            if (index % 2 == 0) {
                hashes[2**(n + 1) - 2**i + index / 2] = PoseidonT3.poseidon(
                    [hashes[index], hashes[index + 1]]
                );
            } else {
                hashes[2**(n + 1) - 2**i + index / 2] = PoseidonT3.poseidon(
                    [hashes[index - 1], hashes[index]]
                );
            }
            index = index / 2;
        }
        index++;
        return hashes[hashes.length - 1];
    }

    function verify(
            uint[2] memory a,
            uint[2][2] memory b,
            uint[2] memory c,
            uint[1] memory input
        ) public view returns (bool) {

         return verifyProof(a, b, c, input);
    }
}
