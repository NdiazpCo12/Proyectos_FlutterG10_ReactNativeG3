import { PropsWithChildren, createContext, useContext } from 'react';

import { container } from './container';

const DIContext = createContext(container);

export function DIProvider({ children }: PropsWithChildren) {
  return <DIContext.Provider value={container}>{children}</DIContext.Provider>;
}

export const useDI = () => useContext(DIContext);
