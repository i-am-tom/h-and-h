var IPFS = require('ipfs');
var Y = require('yjs');

require('y-memory')(Y);
require('y-array')(Y);
require('y-text')(Y);
require('y-ipfs-connector')(Y);

exports.getIpfs = function (repo) {
  return new IPFS({
    repo: repo,
    EXPERIMENTAL: {
      pubsub: true
    }
  });
};

exports.ipfsOnceReadyImpl = function (ipfs) {
  return function (error, success) {
    ipfs.once('ready', success);
  };
};

exports.ipfsIdImpl = function (ipfs) {
  return function (error, success) {
    ipfs.id(function (err, info) {
      if (err) {
        error(err);
      }

      success(info.id);
    });
  };
};

exports.makeYConfig = function (ipfs) {
  return function (room) {
    return {
      db: {
        name: 'memory'
      },
      connector: {
        name: 'ipfs',
        room: room,
        ipfs: ipfs
      },
      share: {
        textfield: 'Text'
      }
    };
  };
};

exports.setupYImpl = function (yConfig) {
  return function (error, success) {
    Y(yConfig).then(success).catch(error);
  };
};

exports.doTheThing = function (y) {
  y.share.textfield.bind(
    document.getElementById('textfield')
  );
};
