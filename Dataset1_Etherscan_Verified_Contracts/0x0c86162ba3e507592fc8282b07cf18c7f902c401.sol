// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2021 Dai Foundation
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
pragma solidity 0.8.13;

import {IJob} from "./interfaces/IJob.sol";

interface SequencerLike {
    function isMaster(bytes32 network) external view returns (bool);
}

interface LitePsmLike {
    function chug() external returns (uint256 wad);
    function cut() external view returns (uint256 wad);
    function fill() external returns (uint256 wad);
    function gush() external view returns (uint256 wad);
    function rush() external view returns (uint256 wad);
    function trim() external returns (uint256 wad);
}

/// @title Call flap when possible
contract LitePsmJob is IJob {
    SequencerLike public immutable sequencer;
    LitePsmLike public immutable litePsm;

    uint256 public immutable rushThreshold;
    uint256 public immutable cutThreshold;
    uint256 public immutable gushThreshold;

    // --- Errors ---
    error NotMaster(bytes32 network);
    error ThresholdNotReached(bytes4 fn);
    error UnsupportedFunction(bytes4 fn);

    // --- Events ---
    event Work(bytes32 indexed network, bytes4 indexed action);

    constructor(
        address _sequencer,
        address _litePsm,
        uint256 _rushThreshold,
        uint256 _cutThreshold,
        uint256 _gushThreshold
    ) {
        sequencer = SequencerLike(_sequencer);
        litePsm = LitePsmLike(_litePsm);
        rushThreshold = _rushThreshold;
        cutThreshold = _cutThreshold;
        gushThreshold = _gushThreshold;
    }

    function work(bytes32 network, bytes calldata args) public {
        if (!sequencer.isMaster(network)) revert NotMaster(network);

        (bytes4 fn) = abi.decode(args, (bytes4));

        if (fn == litePsm.fill.selector) {
            if (litePsm.rush() >= rushThreshold) litePsm.fill();
            else revert ThresholdNotReached(fn);
        } else if (fn == litePsm.chug.selector) {
            if(litePsm.cut() >= cutThreshold) litePsm.chug();
            else revert ThresholdNotReached(fn);
        } else if (fn == litePsm.trim.selector) {
            if (litePsm.gush() >= gushThreshold) litePsm.trim();
            else revert ThresholdNotReached(fn);
        } else {
            revert UnsupportedFunction(fn);
        }

        emit Work(network, fn);
    }

    function workable(bytes32 network) external view override returns (bool, bytes memory) {
        if (!sequencer.isMaster(network)) return (false, bytes("Network is not master"));

        if (litePsm.rush() >= rushThreshold) {
            return (true, abi.encode(litePsm.fill.selector));
        } else if (litePsm.cut() >= cutThreshold) {
            return (true, abi.encode(litePsm.chug.selector));
        } else if (litePsm.gush() >= gushThreshold) {
            return (true, abi.encode(litePsm.trim.selector));
        } else {
            return (false, bytes("No work to do"));
        }
    }
}
// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2021 Dai Foundation
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
pragma solidity >=0.8.0;

/// @title Maker Keeper Network Job
/// @notice A job represents an independant unit of work that can be done by a keeper
interface IJob {

    /// @notice Executes this unit of work
    /// @dev Should revert iff workable() returns canWork of false
    /// @param network The name of the external keeper network
    /// @param args Custom arguments supplied to the job, should be copied from workable response
    function work(bytes32 network, bytes calldata args) external;

    /// @notice Ask this job if it has a unit of work available
    /// @dev This should never revert, only return false if nothing is available
    /// @dev This should normally be a view, but sometimes that's not possible
    /// @param network The name of the external keeper network
    /// @return canWork Returns true if a unit of work is available
    /// @return args The custom arguments to be provided to work() or an error string if canWork is false
    function workable(bytes32 network) external returns (bool canWork, bytes memory args);

}