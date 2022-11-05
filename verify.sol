function verifyFull(
    address[] calldata _owners, 
    uint256[] calldata _prices, 
    uint256 _timeFirst, 
    uint256 _timeSecond, 
    uint256 _value
    ) public  view onlyRound{
        require(exist == true, "Already not exist");
        console.log("Verify Full");

        uint256 _snapPoint = uint256(
            keccak256(
                abi.encodePacked(_timeFirst, _timeSecond, _owners[0], _prices[0], _value)
            )
        );

        for(uint i=1;i<_owners.length;i++){
            _snapPoint = uint256(
                keccak256(abi.encodePacked(_owners[i], _prices[i], _snapPoint))
            );
        }
        require(_snapPoint == snapshot, "Not right verify");

    }


    function verifyOwner(
        address[] memory _owners, 
        uint256[] memory _prices,
        address[] memory _support,
        uint256[] memory _additives,
        uint256 [] memory _sizes,
        uint256 _snap
        ) public view{
        console.log("Verify Owner");
        uint counter;

        for(uint i=0;i<_owners.length;i++){
            _snap = uint256(
                keccak256(abi.encodePacked(_owners[i], _prices[i], _snap))
            );

            for(uint j = counter;j< counter+_sizes[i]; j++){
                _snap = uint256(
                    keccak256(abi.encodePacked(_support[j], _additives[j], _snap))
                );
            }
            counter+=_sizes[i];
        }
        require(_snap == snapshot, "Not right verify");
        require(_prices[0]>_prices[1], "No mistake");
    }


    function CorrectOwner(
        address[] memory _owners, 
        uint256[] memory _prices,
        address[] memory _support,
        uint256[] memory _additives,
        uint256 [] memory _sizes,
        uint256 _snap
        ) public{
        verifyOwner(_owners, _prices, _support, _additives, _sizes, _snap);
        snapshot = _snap;
        console.log("Snapshot is change");
    }
