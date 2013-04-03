
/*
*/


(function() {
  var HMAC_SHA256_MAC, HMAC_SHA256_finalize, HMAC_SHA256_init, HMAC_SHA256_write, SHA256_Ch, SHA256_Hash_Byte_Block, SHA256_Hash_Word_Block, SHA256_K, SHA256_Maj, SHA256_Sigma0, SHA256_Sigma1, SHA256_finalize, SHA256_hash, SHA256_hexchars, SHA256_init, SHA256_sigma0, SHA256_sigma1, SHA256_write, array_to_hex_string, exports, string_to_array;

  string_to_array = function(str) {
    var i, len, res;
    len = str.length;
    res = new Array(len);
    i = 0;
    while (i < len) {
      res[i] = str.charCodeAt(i);
      i++;
    }
    return res;
  };

  array_to_hex_string = function(ary) {
    var i, res;
    res = "";
    i = 0;
    while (i < ary.length) {
      res += SHA256_hexchars[ary[i] >> 4] + SHA256_hexchars[ary[i] & 0x0f];
      i++;
    }
    return res;
  };

  /*
  */


  SHA256_init = function() {
    var SHA256_H, SHA256_buf, SHA256_len;
    SHA256_H = new Array(0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a, 0x510e527f, 0x9b05688c, 0x1f83d9ab, 0x5be0cd19);
    SHA256_buf = new Array();
    return SHA256_len = 0;
  };

  SHA256_write = function(msg) {
    var SHA256_buf, i;
    if (typeof msg === "string") {
      SHA256_buf = SHA256_buf.concat(string_to_array(msg));
    } else {
      SHA256_buf = SHA256_buf.concat(msg);
    }
    i = 0;
    while (i + 64 <= SHA256_buf.length) {
      SHA256_Hash_Byte_Block(SHA256_H, SHA256_buf.slice(i, i + 64));
      i += 64;
    }
    SHA256_buf = SHA256_buf.slice(i);
    return SHA256_len += msg.length;
  };

  SHA256_finalize = function() {
    var i, res;
    SHA256_buf[SHA256_buf.length] = 0x80;
    if (SHA256_buf.length > 64 - 8) {
      i = SHA256_buf.length;
      while (i < 64) {
        SHA256_buf[i] = 0;
        i++;
      }
      SHA256_Hash_Byte_Block(SHA256_H, SHA256_buf);
      SHA256_buf.length = 0;
    }
    i = SHA256_buf.length;
    while (i < 64 - 5) {
      SHA256_buf[i] = 0;
      i++;
    }
    SHA256_buf[59] = (SHA256_len >>> 29) & 0xff;
    SHA256_buf[60] = (SHA256_len >>> 21) & 0xff;
    SHA256_buf[61] = (SHA256_len >>> 13) & 0xff;
    SHA256_buf[62] = (SHA256_len >>> 5) & 0xff;
    SHA256_buf[63] = (SHA256_len << 3) & 0xff;
    SHA256_Hash_Byte_Block(SHA256_H, SHA256_buf);
    res = new Array(32);
    i = 0;
    while (i < 8) {
      res[4 * i + 0] = SHA256_H[i] >>> 24;
      res[4 * i + 1] = (SHA256_H[i] >> 16) & 0xff;
      res[4 * i + 2] = (SHA256_H[i] >> 8) & 0xff;
      res[4 * i + 3] = SHA256_H[i] & 0xff;
      i++;
    }
    delete SHA256_H;
    delete SHA256_buf;
    delete SHA256_len;
    return res;
  };

  SHA256_hash = function(msg) {
    var res;
    res = void 0;
    SHA256_init();
    SHA256_write(msg);
    res = SHA256_finalize();
    return array_to_hex_string(res);
  };

  /*
  */


  HMAC_SHA256_init = function(key) {
    var HMAC_SHA256_key, i;
    if (typeof key === "string") {
      HMAC_SHA256_key = string_to_array(key);
    } else {
      HMAC_SHA256_key = new Array().concat(key);
    }
    if (HMAC_SHA256_key.length > 64) {
      SHA256_init();
      SHA256_write(HMAC_SHA256_key);
      HMAC_SHA256_key = SHA256_finalize();
    }
    i = HMAC_SHA256_key.length;
    while (i < 64) {
      HMAC_SHA256_key[i] = 0;
      i++;
    }
    i = 0;
    while (i < 64) {
      HMAC_SHA256_key[i] ^= 0x36;
      i++;
    }
    SHA256_init();
    return SHA256_write(HMAC_SHA256_key);
  };

  HMAC_SHA256_write = function(msg) {
    return SHA256_write(msg);
  };

  HMAC_SHA256_finalize = function() {
    var i, md;
    md = SHA256_finalize();
    i = 0;
    while (i < 64) {
      HMAC_SHA256_key[i] ^= 0x36 ^ 0x5c;
      i++;
    }
    SHA256_init();
    SHA256_write(HMAC_SHA256_key);
    SHA256_write(md);
    i = 0;
    while (i < 64) {
      HMAC_SHA256_key[i] = 0;
      i++;
    }
    delete HMAC_SHA256_key;
    return SHA256_finalize();
  };

  HMAC_SHA256_MAC = function(key, msg) {
    var res;
    res = void 0;
    HMAC_SHA256_init(key);
    HMAC_SHA256_write(msg);
    res = HMAC_SHA256_finalize();
    return array_to_hex_string(res);
  };

  /*
  */


  SHA256_sigma0 = function(x) {
    return ((x >>> 7) | (x << 25)) ^ ((x >>> 18) | (x << 14)) ^ (x >>> 3);
  };

  SHA256_sigma1 = function(x) {
    return ((x >>> 17) | (x << 15)) ^ ((x >>> 19) | (x << 13)) ^ (x >>> 10);
  };

  SHA256_Sigma0 = function(x) {
    return ((x >>> 2) | (x << 30)) ^ ((x >>> 13) | (x << 19)) ^ ((x >>> 22) | (x << 10));
  };

  SHA256_Sigma1 = function(x) {
    return ((x >>> 6) | (x << 26)) ^ ((x >>> 11) | (x << 21)) ^ ((x >>> 25) | (x << 7));
  };

  SHA256_Ch = function(x, y, z) {
    return z ^ (x & (y ^ z));
  };

  SHA256_Maj = function(x, y, z) {
    return (x & y) ^ (z & (x ^ y));
  };

  SHA256_Hash_Word_Block = function(H, W) {
    var T1, T2, i, state, _results;
    i = 16;
    while (i < 64) {
      W[i] = (SHA256_sigma1(W[i - 2]) + W[i - 7] + SHA256_sigma0(W[i - 15]) + W[i - 16]) & 0xffffffff;
      i++;
    }
    state = new Array().concat(H);
    i = 0;
    while (i < 64) {
      T1 = state[7] + SHA256_Sigma1(state[4]) + SHA256_Ch(state[4], state[5], state[6]) + SHA256_K[i] + W[i];
      T2 = SHA256_Sigma0(state[0]) + SHA256_Maj(state[0], state[1], state[2]);
      state.pop();
      state.unshift((T1 + T2) & 0xffffffff);
      state[4] = (state[4] + T1) & 0xffffffff;
      i++;
    }
    i = 0;
    _results = [];
    while (i < 8) {
      H[i] = (H[i] + state[i]) & 0xffffffff;
      _results.push(i++);
    }
    return _results;
  };

  SHA256_Hash_Byte_Block = function(H, w) {
    var W, i;
    W = new Array(16);
    i = 0;
    while (i < 16) {
      W[i] = w[4 * i + 0] << 24 | w[4 * i + 1] << 16 | w[4 * i + 2] << 8 | w[4 * i + 3];
      i++;
    }
    return SHA256_Hash_Word_Block(H, W);
  };

  SHA256_hexchars = new Array("0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f");

  SHA256_K = new Array(0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5, 0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3, 0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174, 0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da, 0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967, 0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13, 0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85, 0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070, 0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3, 0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208, 0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2);

  exports = {};

  exports.HMAC_SHA256_MAC = HMAC_SHA256_MAC;

}).call(this);
