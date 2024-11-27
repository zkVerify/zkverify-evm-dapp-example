// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract ZkFactorization {
    /// The hash of the identifier of the proving system used (groth16 in this case)
    bytes32 public constant PROVING_SYSTEM_ID =
        keccak256(abi.encodePacked("groth16"));

    /// The address of the ZkvAttestationContract
    address public immutable zkvContract;
    /// The hash of the verification key of the circuit
    bytes32 public immutable vkHash;

    /// A mapping for recording the addresses which have submitted valid proofs
    mapping(address => bool) public hasSubmittedValidProof;

    event SuccessfulProofSubmission(address indexed from);

    constructor(address _zkvContract, bytes32 _vkHash) {
        zkvContract = _zkvContract;
        vkHash = _vkHash;
    }

    function proveYouCanFactor42(
        uint256 attestationId,
        bytes32[] calldata merklePath,
        uint256 leafCount,
        uint256 index
    ) external {
        require(
            _verifyProofHasBeenPostedToZkv(
                attestationId,
                msg.sender,
                merklePath,
                leafCount,
                index
            )
        );
        /// If a valid proof has been posted to zkVerify, then perform app-specific logic (e.g. mint a NFT).
        /// In this simple example, we just record the address of the sender inside a map and emit an event.
        hasSubmittedValidProof[msg.sender] = true;
        emit SuccessfulProofSubmission(msg.sender);
    }

    function _verifyProofHasBeenPostedToZkv(
        uint256 attestationId,
        address inputAddress,
        bytes32[] calldata merklePath,
        uint256 leafCount,
        uint256 index
    ) internal view returns (bool) {
        bytes memory encodedInput = abi.encodePacked(
            _changeEndianess(uint256(uint160(inputAddress)))
        );
        bytes32 leaf = keccak256(
            abi.encodePacked(PROVING_SYSTEM_ID, vkHash, keccak256(encodedInput))
        );

        (bool callSuccessful, bytes memory validProof) = zkvContract.staticcall(
            abi.encodeWithSignature(
                "verifyProofAttestation(uint256,bytes32,bytes32[],uint256,uint256)",
                attestationId,
                leaf,
                merklePath,
                leafCount,
                index
            )
        );

        require(callSuccessful);

        return abi.decode(validProof, (bool));
    }

    /// Utility function to efficiently change the endianess of its input (zkVerify groth16
    /// pallet uses big-endian encoding of public inputs, but EVM uses little-endian encoding).
    function _changeEndianess(uint256 input) internal pure returns (uint256 v) {
        v = input;
        // swap bytes
        v =
            ((v &
                0xFF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00) >>
                8) |
            ((v &
                0x00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF) <<
                8);
        // swap 2-byte long pairs
        v =
            ((v &
                0xFFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000) >>
                16) |
            ((v &
                0x0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF) <<
                16);
        // swap 4-byte long pairs
        v =
            ((v &
                0xFFFFFFFF00000000FFFFFFFF00000000FFFFFFFF00000000FFFFFFFF00000000) >>
                32) |
            ((v &
                0x00000000FFFFFFFF00000000FFFFFFFF00000000FFFFFFFF00000000FFFFFFFF) <<
                32);
        // swap 8-byte long pairs
        v =
            ((v &
                0xFFFFFFFFFFFFFFFF0000000000000000FFFFFFFFFFFFFFFF0000000000000000) >>
                64) |
            ((v &
                0x0000000000000000FFFFFFFFFFFFFFFF0000000000000000FFFFFFFFFFFFFFFF) <<
                64);
        // swap 16-byte long pairs
        v = (v >> 128) | (v << 128);
    }
}
