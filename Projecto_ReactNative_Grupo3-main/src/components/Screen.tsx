import { PropsWithChildren } from 'react';
import { StyleSheet, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';

import { colors } from '../theme/theme';

export function Screen({ children }: PropsWithChildren) {
  return <SafeAreaView style={styles.safe}>{children}</SafeAreaView>;
}

export function HeaderBand({ children }: PropsWithChildren) {
  return <View style={styles.header}>{children}</View>;
}

const styles = StyleSheet.create({
  safe: {
    flex: 1,
    backgroundColor: colors.background,
  },
  header: {
    backgroundColor: colors.primary,
    paddingHorizontal: 22,
    paddingBottom: 22,
    paddingTop: 18,
  },
});
