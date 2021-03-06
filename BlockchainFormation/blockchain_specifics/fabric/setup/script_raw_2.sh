
installBenchcontractChaincode () {

    if (test "$CHANNEL_NAME" = "mychannel1"); then
      PEER=$1
      ORG=$2
      setGlobals $PEER $ORG
      peer chaincode install -l node -n benchcontract -v 1.0 -p /opt/gopath/src/github.com/hyperledger/fabric/examples/chaincode/benchcontract substitute_tls>&log.txt
      res=$?
      cat log.txt
      verifyResult $res "Benchcontract chaincode installation on remote peer PEER$PEER.ORG$ORG has Failed"
      echo "$(date +'%Y-%m-%d %H:%M:%S:%3N')   ===================== Benchcontract chaincode successfully installed on remote peer PEER$PEER.ORG$ORG ===================== "
      echo
    fi
}

instantiateBenchcontractChaincode () {
    PEER=$1
    ORG=$2
    setGlobals $PEER $ORG
    peer chaincode instantiate -o orderer1.example.com:7050 -C $CHANNEL_NAME -l node -n benchcontract -v 1.0 -c '{"Args":["org.bench.benchcontract:instantiate", "substitute_keyspace"]}' -P 'substitute_endorsement' --collections-config /opt/gopath/src/github.com/hyperledger/fabric/examples/chaincode/benchcontract/collections.json substitute_tls>&log.txt
    res=$?
    cat log.txt
      verifyResult $res "$(date +'%Y-%m-%d %H:%M:%S:%3N') Benchcontract chaincode instantiation on PEER$PEER.orgORG1 on channel '$CHANNEL_NAME' failed"
    echo "$(date +'%Y-%m-%d %H:%M:%S:%3N')   ===================== Benchcontract chaincode instantiation on PEER$PEER.ORG$ORG on channel '$CHANNEL_NAME' was successful ===================== "
    echo
}

benchcontractChaincodeQuery () {
    PEER=$1
    ORG=$2
    setGlobals $PEER $ORG
    echo "$(date +'%Y-%m-%d %H:%M:%S:%3N')   ===================== Querying benchcontract chaincode on PEER$PEER.ORG$ORG on channel '$CHANNEL_NAME'... ===================== "
    local rc=1
    local starttime=$(date +%s)

    # continue to poll
    # we either get a successful response, or reach TIMEOUT
    while test "$(($(date +%s)-starttime))" -lt "$TIMEOUT" -a $rc -ne 0
    do
        sleep 10
        echo "Attempting to query benchcontract chaincode on PEER$PEER.ORG$ORG ...$(($(date +%s)-starttime)) secs"
        # peer chaincode query -C $CHANNEL_NAME -n benchcontract -c '{Args":["doNothing"]}' >& log.txt \
        # peer chaincode query -C $CHANNEL_NAME -n benchcontract -c '{Args:["writeData", "testkey", "testvalue"]}' substitute_tls >& log.txt \
        peer chaincode query -C $CHANNEL_NAME -n benchcontract -c '{"Args":["matrixMultiplication","3"]}' substitute_tls >& log.txt \
        # peer chaincode query -C $CHANNEL_NAME -n benchcontract -c '{Args:["readData", "testkey"]}' substitute_tls >& log.txt \
        # peer chaincode query -C $CHANNEL_NAME -n benchcontract -c '{Args:["writeMuchData", "100", "10", "90"]}' substitute_tls >& log.txt \
        # peer chaincode query -C $CHANNEL_NAME -n benchcontract -c '{Args:["readMuchData", "20", "30"]}' substitute_tls >& log.txt
        # res=$?
        # cat log.txt
        # verifyResult $res "Benchcontract chaincode instantiation on PEER$PEER.orgORG1 on channel '$CHANNEL_NAME' failed"
        # test $? -eq 0 && VALUE=$(cat log.txt | awk "/Query Result/ {print $NF}")
        # test "$VALUE" = "$2" && let rc=0
        test $? -eq 0 && let rc=0

    done
    echo
    cat log.txt
    if test $rc -eq 0; then
       echo "$(date +'%Y-%m-%d %H:%M:%S:%3N')   ===================== Benchcontract chaincode query on PEER$PEER.ORG$ORG on channel '$CHANNEL_NAME' was successful ===================== "
       echo
    else
        echo "!!!!!!!!!!!!!!! Benchcontract chaincode query result on PEER$PEER.ORG$ORG is INVALID !!!!!!!!!!!!!!!!"
        echo "$(date +'%Y-%m-%d %H:%M:%S:%3N')   ================== ERROR !!! FAILED to execute End-2-End Scenario =================="
        echo
        exit 1
    echo
    echo
    echo
    fi
}

benchcontractChaincodeInvoke () {
    PEER=$1
    ORG=$2
    setGlobals $PEER $ORG
    echo "$(date +'%Y-%m-%d %H:%M:%S:%3N')   ===================== Invoking benchcontract chaincode on PEER$PEER.ORG$ORG on channel '$CHANNEL_NAME'... ===================== "
    # while "peer chaincode" command can get the orderer endpoint from the peer (if join was successful),
    # lets supply it directly as we know it using the "-o" option
    # peer chaincode invoke -o orderer1.example.com:7050 -C $CHANNEL_NAME -n benchcontract -c '{Args":["doNothing"]}' >& log.txt && \
    # peer chaincode invoke -o orderer1.example.com:7050 -C $CHANNEL_NAME -n benchcontract -c '{Args:["writeData", "testkey", "testvalue"]}' substitute_tls >& log.txt && \
    peer chaincode invoke -o orderer1.example.com:7050 -C $CHANNEL_NAME -n benchcontract -c '{"Args":["matrixMultiplication","3"]}' substitute_tls >& log.txt \
    # peer chaincode invoke -o orderer1.example.com:7050 -C $CHANNEL_NAME -n benchcontract -c '{Args:["readData", "testkey"]}' substitute_tls >& log.txt && \
    # peer chaincode invoke -o orderer1.example.com:7050 -C $CHANNEL_NAME -n benchcontract -c '{Args:["writeMuchData", "100", "10", "90"]}' substitute_tls >& log.txt && \
    # peer chaincode invoke -o orderer1.example.com:7050 -C $CHANNEL_NAME -n benchcontract -c '{Args:["readMuchData", "20", "30"]}' substitute_tls >& log.txt
    res=$?
    cat log.txt
    verifyResult $res "Benchcontract chaincode invoke execution on PEER$PEER.ORG$ORG failed "
    echo "$(date +'%Y-%m-%d %H:%M:%S:%3N')   ===================== Benchcontract chaincode invoke transaction on PEER$PEER.ORG$ORG on channel '$CHANNEL_NAME' was successful ===================== "
    echo
    sleep 2
}


# Installing benchcontract chaincode on all peers
echo "$(date +'%Y-%m-%d %H:%M:%S:%3N') Installing chaincode on peers..."
for PEER in substitute_enum_peers; do
    for ORG in substitute_enum_orgs; do
        installBenchcontractChaincode $PEER $ORG
    done
done

#Instantiating benchcontract chaincode on peer0.org1
echo "$(date +'%Y-%m-%d %H:%M:%S:%3N') Instantiating benchcontract chaincode on peer0.org1..."
for PEER in 0; do
    for ORG in 1; do
        instantiateBenchcontractChaincode $PEER $ORG
    done
done

#Querying example and benchcontract chaincode on all peers
echo "$(date +'%Y-%m-%d %H:%M:%S:%3N') Querying benchcontract chaincode on all peers"
for PEER in substitute_enum_peers; do
    for ORG in substitute_enum_orgs; do
        sleep 2
        benchcontractChaincodeQuery $PEER $ORG &
    done
done

wait

# Invoking benchcontract chaincode on all peers
echo "$(date +'%Y-%m-%d %H:%M:%S:%3N') Invoking benchcontract chaincode on all peers"
for PEER in substitute_enum_peers; do
    for ORG in substitute_enum_orgs; do
        benchcontractChaincodeInvoke $PEER $ORG &
    done
done

wait

# Querying benchcontract chaincode on all peers
echo "$(date +'%Y-%m-%d %H:%M:%S:%3N') Querying benchcontract chaincode on all peers"
for PEER in substitute_enum_peers; do
    for ORG in substitute_enum_orgs; do
        benchcontractChaincodeQuery $PEER $ORG &
    done
done

wait

echo
echo
echo "========= All GOOD, script completed =========== "

exit 0