const robleClientMock = {
  read: jest.fn(() => Promise.resolve([])),
  insert: jest.fn(() => Promise.resolve('mock-id')),
  update: jest.fn(() => Promise.resolve()),
  delete: jest.fn(() => Promise.resolve()),
  deleteById: jest.fn(() => Promise.resolve()),
};

module.exports = { robleClient: robleClientMock };
