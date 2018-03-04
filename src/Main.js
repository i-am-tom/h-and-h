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

exports.doTheThing = function (ipfs) {
  Y({
    db: {
      name: 'memory'
    },
    connector: {
      name: 'ipfs',
      room: 'hardy-and-harding',
      ipfs: ipfs
    },
    share: {
      textfield: 'Text'
    }
  }).then(function (y) {
    y.share.textfield.bind(
      document.getElementById('textfield')
    );
  });
};
