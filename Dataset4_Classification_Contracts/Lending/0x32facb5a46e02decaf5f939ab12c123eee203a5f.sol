# @version 0.3.10
"""
@title MultiClaim
"""

struct Stream:
    addr: address
    receiver: address


interface Vault:
    def claim(_for: address): nonpayable
    def claim_all(): nonpayable


@external
def claim(vaults: DynArray[Stream, 20]):
    for vault in vaults:
        if vault.receiver == empty(address):
            Vault(vault.addr).claim_all()
        else:
            Vault(vault.addr).claim(vault.receiver)