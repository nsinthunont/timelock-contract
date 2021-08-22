const { expectRevert, constants, time } = require('@openzeppelin/test-helpers');
const { assert } = require('chai');

const THIRTY_DAYS = time.duration.days(30).toNumber();

describe("Timelock", function () {

  let timelock, nstoken, depositor, recipient;

  beforeEach(async () => {

    const Timelock = await ethers.getContractFactory("Timelock");
    timelock = await Timelock.deploy();
    await timelock.deployed()

    const NSToken = await ethers.getContractFactory("NSToken");
    nstoken = await NSToken.deploy();
    await nstoken.deployed();

    [_, depositor, recipient] = await ethers.getSigners();

    await nstoken.transfer(depositor.address, 1000);
    await nstoken.connect(depositor).approve(timelock.address, 1000);
    

  });

  it("deposit tokens then withdraw", async function () {

    await timelock.connect(depositor).depositTokens(depositor.address, recipient.address, nstoken.address, 10, THIRTY_DAYS);

    await expectRevert.unspecified(
      timelock.connect(depositor).withdrawTokens(1, recipient.address)
    );

    assert((await nstoken.balanceOf(depositor.address)).toNumber() == 990, "depositor balance should be 990");
    assert((await nstoken.balanceOf(recipient.address)).toNumber() == 0, "recipient balance should be 0");
    assert((await nstoken.balanceOf(timelock.address)).toNumber() == 10, "timelock balance should be 10");

    await time.increase(time.duration.days(30).toNumber());

    await timelock.connect(depositor).withdrawTokens(1, recipient.address);

    assert((await nstoken.balanceOf(recipient.address)).toNumber() == 10, "recipient balance should be 10");
    assert((await nstoken.balanceOf(timelock.address)).toNumber() == 0, "timelock balance should be 0");
    
  });

});
